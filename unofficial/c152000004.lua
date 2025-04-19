--種の保存
--Minus Mitosis
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EVENT_SPSUMMON_SUCCESS)
end
function s.cfilter(c)
	return c:IsLinkMonster() and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return eg:IsExists(s.cfilter,1,nil) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Skill Negation Check
	if aux.CheckSkillNegation(e,tp) then return end
	--Minus Mitosis
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetAttack()/2)
		tc:RegisterEffect(e1)
	end
end