--エレキック・アンプル
--Elechic Ampoule
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.recfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHIC) and c:IsLevelBelow(2) and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.recfilter,tp,LOCATION_MZONE,0,1,2,nil)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1 and tc1:IsFaceup() then
		local atk=tc1:GetAttack()
		if tc2 and tc2:IsFaceup() then
			atk=atk+tc2:GetAttack()
		end
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
