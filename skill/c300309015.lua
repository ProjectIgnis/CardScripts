--Desert's Peril
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Switch monsters to face-down position and shuffle, then change position of 1 monster
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetCondition(s.poscon)
	e1:SetOperation(s.posop)
	Duel.RegisterEffect(e1,tp)
end
function s.poscon(e)
	local tp=e:GetHandlerPlayer()
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsCanTurnSet),tp,LOCATION_MZONE,0,1,nil) and not Duel.HasFlagEffect(tp,id,2)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--You can only use this Skill twice per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Change all monsters to face-down Defense Position and shuffle, then you can change 1 of your monster's battle position
	local posg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(aux.AND(Card.IsMonster,Card.IsCanTurnSet),nil)
	if #posg>0 then
		Duel.ChangePosition(posg,POS_FACEDOWN_DEFENSE)
		Duel.ShuffleSetCard(posg)
		if Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsCanChangePosition),tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local fg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,0,1,1,nil)
			if #fg>0 then
				Duel.HintSelection(fg,true)
				Duel.ChangePosition(fg,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end