--Professor of Alchemy
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={27408609}
function s.rmvfilter(c)
	return c:IsLevelBelow(4) and c:HasLevel() and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Banish 1 Level 4 or lower monster to Special Summon 1 "Alchemy Beast Token"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 and Duel.GetMatchingGroupCount(s.rmvfilter,tp,LOCATION_MZONE,0,nil)>0 then
		loc=LOCATION_MZONE
	else
		loc=LOCATION_HAND+LOCATION_ONFIELD
	end
	local g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,loc,0,1,1,nil):GetFirst()
	if Duel.Remove(g,POS_FACEUP,REASON_COST)>0 then 
		local og=Duel.GetOperatedGroup():GetFirst()
		local att=0
		if og:IsPreviousLocation(LOCATION_ONFIELD) then
			att=og:GetPreviousAttributeOnField()
		else
			att=og:GetAttribute()
		end
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,946,SET_ALCHEMY_BEAST,TYPES_TOKEN,300,300,3,RACE_ROCK,att,POS_FACEUP) then
			local token=Duel.CreateToken(tp,946)
			if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
				--Set stats/Type
				local e0a=Effect.CreateEffect(c)
				e0a:SetType(EFFECT_TYPE_SINGLE)
				e0a:SetCode(EFFECT_CHANGE_RACE)
				e0a:SetRange(LOCATION_MZONE)
				e0a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
				e0a:SetValue(RACE_ROCK)
				token:RegisterEffect(e0a,true)
				local e0b=e0a:Clone()
				e0b:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
				e0b:SetValue(300)
				token:RegisterEffect(e0b,true)
				local e0c=e0a:Clone()
				e0c:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
				e0c:SetValue(300)
				token:RegisterEffect(e0c,true)
				local e0d=e0a:Clone()
				e0d:SetCode(EFFECT_CHANGE_LEVEL)
				e0d:SetValue(3)
				token:RegisterEffect(e0d,true)
				local e0e=e0a:Clone()
				e0e:SetCode(EFFECT_CHANGE_SETCODE)
				e0e:SetValue(SET_ALCHEMY_BEAST)
				token:RegisterEffect(e0e,true)
				--Change Attribute to that of banished monster
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(att)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1)
				--"Alchemy Beast Tokens" can attack directly
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DIRECT_ATTACK)
				token:RegisterEffect(e2)
				--Cannot be Tributed, except to Tribute Summon "Golden Homunculus"
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetRange(LOCATION_MZONE)
				e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e3:SetValue(1)
				c:RegisterEffect(e3)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_UNRELEASABLE_SUM)
				e4:SetValue(function(e,c) return not c:IsCode(27408609) end)
				c:RegisterEffect(e4)
			end
		end
	end
end
