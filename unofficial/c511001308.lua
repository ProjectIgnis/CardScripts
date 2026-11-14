--パワーブースター Ｌｖ２
--Lev. 2 Power Boost
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Level 2 or lower Insect-Type monster.
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--Triple the ATK boost gained from 1 other Equip Card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.atkadjcon)
	e1:SetOperation(s.atkadjop)
	c:RegisterEffect(e1)
end
function s.eqfilter(c)
	return c:IsLevelBelow(2) and c:IsRace(RACE_INSECT)
end
function s.runfn(fn,eff,tp,chk)
	return not fn or fn(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,nil,REASON_EFFECT,PLAYER_NONE,chk)
end
function s.atkadjfilter(c,tp)
	if not c:IsEquipSpell() then return false end
	for _,eff in ipairs({c:GetOwnEffects()}) do
		if eff:GetCode()==EFFECT_UPDATE_ATTACK and s.runfn(eff:GetCondition(),eff,tp,0) then return true end
	end
	return false
end
function s.atkadjcon(e)
	local c=e:GetHandler()
	local eqg=c:GetEquipTarget():GetEquipGroup()
	return c:IsFaceup() and eqg:IsExists(s.atkadjfilter,1,c,tp) and not c:HasFlagEffect(id) 
end
function s.atkadjop(e,tp,eg,ep,ev,re,r,rp)
	Duel.AdjustInstantly()
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	local eqg=eqc:GetEquipGroup():Filter(s.atkadjfilter,c,tp)
	if #eqg==0 then return end
	local effs={eqc:GetCardEffect(EFFECT_UPDATE_ATTACK)}
	local effg=Group.CreateGroup()
	for _,eff in ipairs(effs) do
		local effc=eff:GetOwner()
		if effc:IsEquipCard() and effc:GetEquipTarget()==eqc and effc~=c then
			effg:AddCard(effc)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local ec=effg:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(ec)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	for _,eceff in ipairs({ec:GetOwnEffects()}) do
		if eceff:GetCode()==EFFECT_UPDATE_ATTACK and eceff:GetHandler():GetEquipTarget()==eqc then
			Duel.Hint(HINT_CARD,0,id)
			local effval=eceff:GetValue()
			eceff:SetValue(effval*3)
		end
	end
end
