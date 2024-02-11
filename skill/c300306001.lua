--Ruthless Means
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_EVIL_HERO}
function s.cfilter(c)
	return c:IsSetCard(SET_EVIL_HERO) and c:IsMonster() and c:IsFaceup()
end
function s.opfilter(c)
	return c:IsMonster() and c:IsFaceup() and (c:HasNonZeroAttack() or c:HasNonZeroDefense())
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.opfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card to reduce ATK by DEF or DEF by ATK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)~=0 then
 		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
 		local tc=Duel.SelectMatchingCard(tp,s.opfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
 		local atk=tc:GetAttack()
 		local def=tc:GetDefense()
 		if tc then
 			local op=Duel.SelectEffect(tp,{tc:GetAttack()>0,aux.Stringid(id,0)},{tc:GetDefense()>0,aux.Stringid(id,1)})
 			if op==1 then
 				--Reduce ATK by monster's DEF
 				local e1=Effect.CreateEffect(e:GetHandler())
 				e1:SetType(EFFECT_TYPE_SINGLE)
 				e1:SetCode(EFFECT_UPDATE_ATTACK)
 				e1:SetRange(LOCATION_MZONE)
 				e1:SetValue(-def)
 				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
 				tc:RegisterEffect(e1)
 			elseif op==2 then
 				--Reduce DEF by monster's ATK
 				local e1=Effect.CreateEffect(e:GetHandler())
 				e1:SetType(EFFECT_TYPE_SINGLE)
 				e1:SetCode(EFFECT_UPDATE_DEFENSE)
 				e1:SetRange(LOCATION_MZONE)
 				e1:SetValue(-atk)
 				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
 				tc:RegisterEffect(e1)

 			end
 		end
 	end
end