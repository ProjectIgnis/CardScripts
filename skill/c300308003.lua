--Food Chain
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
--Filter to check for destructible monsters/monsters with 1 higher Level in the controller's hand/Deck
function s.desfilter(c,e,tp,ft)
	return (c:IsRace(RACE_DINOSAUR) or c:IsRace(RACE_REPTILE)) and c:HasLevel() and c:IsDestructable() and ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,c:GetLevel()+1,e,tp)
end
function s.spfilter(c,lv,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,c)
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	--opt check
	local b1=Duel.GetFlagEffect(tp,id)==0 and ft>-1 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.GetFlagEffect(tp,id+200)==0 
	--Condition check
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=Duel.GetFlagEffect(tp,id)==0 and ft>-1 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.GetFlagEffect(tp,id+200)==0
	if not (b1 or b2) then return false end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if (b1 and op==1) or (Duel.GetFlagEffect(tp,id+100)>0 or Duel.GetFlagEffect(tp,id+200)>0) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
			local lv=tg:GetFirst():GetLevel()
			if Duel.Destroy(tg,REASON_COST)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,lv+1,e,tp)
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
	 elseif (b2 and op==2) or Duel.GetFlagEffect(tp,id)>0 then
			Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SUMMON_PROC)
			e1:SetTargetRange(LOCATION_HAND,0)
			e1:SetCondition(s.otcon)
			e1:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
			e1:SetOperation(s.otop)
			e1:SetCountLimit(1)
			e1:SetValue(SUMMON_TYPE_TRIBUTE)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_PROC)
			Duel.RegisterEffect(e2,tp)
			Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1)
	end
end
--Tribute replacement functions
function s.tribrepfilter(c)
	return (c:IsRace(RACE_DINOSAUR) or c:IsRace(RACE_REPTILE)) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tribrepfilter,tp,LOCATION_GRAVE,0,2,nil)
end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsRace(RACE_DINOSAUR)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tribrepfilter,tp,LOCATION_GRAVE,0,2,2,true,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
end