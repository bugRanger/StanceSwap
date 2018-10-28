local gStance={"Battle Stance","Defensive Stance","Berserker Stance"}
local addons = "StanceSwap"

local function Message(text)
	DEFAULT_CHAT_FRAME:AddMessage(addons .. ": " .. text);
end

Message("Hello!")

function stsw(stActive,stEvent,stReturn)
	StanceSwap(stActive,stEvent,stReturn);
end
function stev(stSpell)
	return pcall(CastSpellByName,stSpell);
end
function StanceSwap(stSwap,stSpell,stReturn)
	StanceSwapEv(stSwap, stev(stSpell), stReturn)
end

--???:
function spcd(slot)
	local start,_,_ = GetActionCooldown(slot)
	return (start == 0);
end
--???:
function sprn(slot)
	local inRange = IsActionInRange(slot)
	return (inRange == 1);
end
--???:
function spac(slot, mana)
	local isUsable, notEnoughMana = IsUsableAction(slot)
	return (inRange == 1) and (notEnoughMana == nil or mana == nil);
end

--???:
local function Contains(stSwaped)
	for stateId, stateName in ipairs(gStance) do
		for _, swapId in ipairs(stSwaped) do
			if (stateId == swapId)then
				return stateId, stateName;
			end;
		end;
	end;
end;
--???:
local function SwapStanceEx(stSwap)
	-- Find non active stance
	local id, name = Contains(stSwap);
	-- Check
	if (id == nil) then	
		Message("ERROR! Not contains stance numbers - {" .. table.concat(stSwap, ",") .. "}");
		return
	else
		-- Get inf stance
		_,_,_act,_ = GetShapeshiftFormInfo(stSwap[1]);
		s,_,_ = GetShapeshiftFormCooldown(stSwap[1]);
		-- Check
		if not _act then 
			-- Activation stance
			SpellStopCasting()CastSpellByName(name)
		end;
		-- Return state.
		return (s == 0)
	end;
end;
--???:
function StanceSwapEv(stSwap,stEvent,stReturn)
	-- Array of stance for swap is null
	if stSwap == nil then		
		Message("Array of stance is null");
		return;
	end	
	-- Check
	if stEvent == nil then
		Message("ERROR! Event is null!");
		return;
	end;	
	-- Get cast name
	local cast = stEvent();
	if cast == nil or cast == "" then
		Message("ERROR! Event not return cast name!");
		return;
	end;	
	-- Find non active stance
	local ready = SwapStanceEx(stSwap);	
	-- Check event is not nil and ready state
	if stReturn == nil or not ready then return else 		
		-- Cast result.
		local result = false;		
		-- Get inf stance
		s,_,_ = GetShapeshiftFormCooldown(stReturn);
		-- Find spell inf from book
		for i = 1, MAX_SKILLLINE_TABS do
			-- Get inf spell
			local tab, _, offset, numSpells = GetSpellTabInfo(i);			
			-- Slot spell
			for slotID = offset + 1, offset + numSpells do						
				-- Get name spell slot
				local spell,_ = GetSpellName(slotID, BOOKTYPE_SPELL);
				-- Check
				if spell == cast then
					-- Get spell ready
					st,_,_ = GetSpellCooldown(slotID, BOOKTYPE_SPELL);
					-- Check ready
					if s > 0 or st > 0 then 
						return 
					else
						-- Attempt cast
						result = pcall(CastSpellByName, cast);
						-- Check
						if result then
							-- Return stance
							SwapStanceEx({stReturn});
						end;
					end					
					-- Return result
					return result;
				end
			end
		end
	end 
end