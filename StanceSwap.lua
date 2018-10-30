-- ANI.MOCK> Исп. методы API.
-- Получить информацию о восстановление действия.
-- local function GetActionCooldown(slotID)
	-- local start = 0;
	-- return start,0,0;
-- end;
-- -- Получить информацию о дистанции действия.
-- local function IsActionInRange(slotID)
	-- return 1;
-- end;
-- -- Получить информацию о ресурсе действия.
-- local function IsUsableAction(slotID)
	-- return 1, nil;
-- end;
-- -- Прервать выполнение действия.
-- local function SpellStopCasting()
-- end;
-- -- Выполнить действие.
-- local function UseAction(slotID)
-- end;
-- -- Выполнить заклинание.
-- local function CastSpellByName(name)
-- end;
-- -- Выполнить заклинание.
-- local function GetShapeshiftFormInfo(stanceID)
	-- local act = true;
	-- return 0,0,act,0;
-- end;
-- -- Выполнить заклинание.
-- local function GetShapeshiftFormCooldown(stanceID)
	-- local start = 0;
	-- return start,0,0;
-- end;
-- ANI.MOCK<
local gStance={"Battle Stance","Defensive Stance","Berserker Stance"}
local addons = "StanceSwap"

local function Message(text)
	DEFAULT_CHAT_FRAME:AddMessage(addons .. ": " .. text);
end

Message("Loaded!");

-- Проверка на восстановление.
-- > slotID - Номер слота действия на панели.
function actcd(slotID)
	local start,_,_ = GetActionCooldown(slotID)
	return (start == 0);
end
-- Проверка на доступность в дистанции.
-- > slotID - Номер слота действия на панели.
function actrng(slotID)
	local inRange = IsActionInRange(slotID)
	return (inRange == 1);
end
-- Проверка на возможность использовать.
-- > slotID - Номер слота действия на панели.
-- > resource - флаг проверки наличия ресурсов для выполнения.
function actuse(slotID, resource)
	local isUsable, notEnoughMana = IsUsableAction(slotID)
	return (isUsable == 1) and (notEnoughMana == nil or resource == nil);
end
-- Выполняем поиск вхождений для массива стоек.
-- > stances - Массив стоек.
-- > predicate - Условие для нахождения совпадения.
local function GetContains(stances, predicate)
	for stateId, stateName in ipairs(gStance) do
		for _, swapId in ipairs(stances) do
			if stateId == swapId and (predicate == nil or predicate(stateId)) then
				return stateId, stateName;
			end;
		end;
	end;
end;
-- Смена стойки.
-- > stances - Массив стоек.
-- > before - Событие до смены стойки.
-- > after - Событие после смены стойки.
local function SetStance(stances, before, after)
	-- Поиск стоек.
	if stances == nil or next(stances) == nil then
		return;
	end
	-- Ищем одну из необходимых для активации стоек.
	local stanceID, name = GetContains(stances,
		-- Поиск акт. стоек.
		function(stanceID)
			-- Получаем информацию о стойке.
			local _,_,_act,_ GetShapeshiftFormInfo(stanceID);
			return _act;
		end);
	-- Если акт. стоек нет, берем приоритетную.
	if stanceID == nil then
		stanceID, name = GetContains({stances[1]});
	end;	
	-- Получаем информацию о стойке.
	local _,_,act,_ = GetShapeshiftFormInfo(stanceID);
	local start,_,_ = GetShapeshiftFormCooldown(stanceID);
	-- Доступна к выполнению.
	if start == 0 then		
		-- Активация стойки.
		if not act then			
			-- Выполняем действия ДО.
			if before ~= nil then
				before();
			end 
			-- Выполняем.
			SpellStopCasting()CastSpellByName(name);
		end
		-- Выполняем действия ПОСЛЕ.
		if after ~= nil then
			after();
		end
	end;
	-- Возвращаем состояние.
	return (not act);
end;
-- Проверка доступности действия.
-- ANI.HINT> Выполняем по флагу. возрастания.
local function GetReady(slots)
	local result = false;
	-- Проверяем.
	if slots == nil then
		-- Возвращаем результат.
		return result;
	end
	-- Получаем первый элемент.
	for slotID, check in pairs(slots) do
		-- Проверяем.
		if slotID == nil then
			-- Возвращаем результат.
			return result;
		end;
		-- Проверка на наличие условия.
		if check == nil or check == 0 then
			-- Возвращаем результат.
			return true;
		end
		-- ANI.HINT>
		-- нет кд и ({есть дистанция, есть ресурс} или {есть ресурс, есть дистанция})
		-- Используя движения из положительных флагов в отрицательные {-3 -2 -1 0 1 2 3}
		-- Т.к. некоторые способности могут требовать ресурс и дистанцию или же ресурс или дистанцию.
		--Проверка на восстановление действия.
		result = actcd(slotID)
		-- Проверка на дистанцию действия.
		if check > 1 or check < -2 then
			result = result and actrng(slotID);
		end
		-- Проверка на ресурс действия.
		if check > 2 or check < -1 then 
			result = result and actuse(slotID, 1);
		end;
		-- Возвращаем результат.
		return result;
	end;	
end

-- Проверка и вызов действий в стойке, с последующим завершением действиями и возвратом в стойку.
-- > inStances - Массив стоек для действий ДО итоговой стойки.
-- > inBefore - Массив действий ДО.
-- > inAfter - Массив действий ПОСЛЕ.
-- > outStance - Итоговая стойка.
-- > outBefore - Массив действий ДО.
-- > outAfter - Массив действий ПОСЛЕ.
function ssp(inStances,inBefore,inAfter,outStance,outBefore,outAfter)
	StanceSwaped(inStances,inBefore,inAfter,outStance,outBefore,outAfter);
end;
-- Проверка и вызов действий в стойке, с последующим завершением действиями и возвратом в стойку.
-- > inStances - Массив стоек для действий ДО итоговой стойки.
-- > inBefore - Массив действий ДО.
-- > inAfter - Массив действий ПОСЛЕ.
-- > outStance - Итоговая стойка.
-- > outBefore - Массив действий ДО.
-- > outAfter - Массив действий ПОСЛЕ.
function StanceSwaped(inStances,inBefore,inAfter,outStance,outBefore,outAfter)
	-- Проверка массива стоек.
	if inStances == nil or next(inStances) == nil then
		Message("Ошибка! Массив стоек для действий пуст или имеет неверный формат.");
		return;
	end
	-- Выполняем проверку готовности/доступности заклинаний перед сменой стоек.
	-- ANI.HINT> Приоритетный - первые элементы массива действий.
	-- Ожидаем полную готовность/доступность приоритетных действий.
	if 
	(inBefore == nil or (next(inBefore) and GetReady(inBefore)))
		and(inAfter == nil or (next(inAfter) and GetReady(inAfter)))
	and
	(outBefore == nil or (next(outBefore) and GetReady(outBefore)))
		and(outAfter == nil or (next(outAfter) and GetReady(outAfter)))
	then
		-- Смена стойки для действий ДО.
		if not SetStance(inStances,
			function()
				if inBefore ~= nil and next(inBefore) ~= nil then
					for act,_ in pairs(inBefore) do
						SpellStopCasting()UseAction(act);
					end
				end
			end,
			function()
				if inAfter ~= nil and next(inAfter) ~= nil then
					for act,_ in pairs(inAfter) do
						SpellStopCasting()UseAction(act);
					end;
				end;
			end) 
		then
			-- Смена стойки для выполнения ПОСЛЕ.
			SetStance({outStance},
				function()
					if outBefore ~= nil and next(outBefore) ~= nil 
					then
						for act,_ in pairs(outBefore) do
							SpellStopCasting()UseAction(act);
						 end;
					end;
				end,
				function()
					if outAfter ~= nil and next(outAfter) ~= nil then
						for act,_ in pairs(outAfter) do
							SpellStopCasting()UseAction(act);
						end
					end;
				end);
		end;
	end
end