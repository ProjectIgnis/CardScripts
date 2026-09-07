--妖神－不知火
--Shiranui Squiresaga
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can only Special Summon "Shiranui Squiresaga(s)" once per turn.
	c:SetSPSummonOnce(id)
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Once per turn: You can banish 1 face-up monster you control or in your GY, then apply these effects, in sequence, depending on what the monster was before it was banished
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsAbleToRemove() and c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,300)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		local g3=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		--● Zombie: You can have all monsters you control gain 300 ATK
		if tc:IsRace(RACE_ZOMBIE) and #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			for t1 in g1:Iter() do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(300)
				t1:RegisterEffect(e1)
			end
		end
		--● FIRE: You can destroy 1 Spell/Trap on the field
		if tc:IsAttribute(ATTRIBUTE_FIRE) and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local t2=g2:Select(tp,1,1,nil)
			Duel.HintSelection(t2)
			Duel.Destroy(t2,REASON_EFFECT)
		end
		--● Synchro: You can destroy 1 monster on the field
		if tc:IsType(TYPE_SYNCHRO) and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local t3=g3:Select(tp,1,1,nil)
			Duel.HintSelection(t3)
			Duel.Destroy(t3,REASON_EFFECT)
		end
	end
end