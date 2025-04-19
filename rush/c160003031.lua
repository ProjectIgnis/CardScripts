--獣機界覇者キングコンボイ・ライガオン
--Beast Gear King Convoy Liogon

local s,id=GetID()
function s.initial_effect(c)
	--Gain ATK equal to the sum of the sent monsters' levels x 100
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsLevelBelow(4) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,2,e:GetHandler()) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,2,2,e:GetHandler())
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>1 then
		--Gain ATK
		local lv=(g:GetFirst():GetLevel())+(g:GetNext():GetLevel())
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		e1:SetValue(lv*100)
		c:RegisterEffect(e1)
		--Attack limit
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetValue(s.bttg)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e3)
		--Other monsters cannot attack
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_ATTACK)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(s.ftarget)
		e4:SetLabel(c:GetFieldID())
		e4:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e4,tp)
		--Attack all
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetValue(1)
		e5:SetCode(EFFECT_ATTACK_ALL)
		e5:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e5)
	end
end
function s.bttg(e,c)
	return not c:IsAttackPos()
end
function s.ftarget(e,c)
	return c:GetFieldID()~=e:GetLabel()
end