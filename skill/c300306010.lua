--Dragon Force
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.dfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsMonster()
end
function s.rmvfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:HasLevel() and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c) and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Banish 1 Dragon Normal Monster from GY to give piecring/ATK gain to Dragon Normal monster on field
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	local atk=tc:GetLevel()*200
	if Duel.Remove(tc,POS_FACEUP,REASON_COST)>0 and tc:IsPreviousLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sc=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		if sc then
			--Gains 200x Level of banished monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			sc:RegisterEffect(e1)
			--Gains piercing damage
			local e2=e1:Clone()
			e2:SetCode(EFFECT_PIERCE)
			sc:RegisterEffect(e2)
		end
	end
end