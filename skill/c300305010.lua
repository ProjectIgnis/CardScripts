--Elements of Thunder,Water,and Wind
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end 
s.listed_names={25833572,25955164,62340868,98434877}
function s.cfilter(c,tp)
	return c:IsCode(25955164) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,tp)  
end
function s.cfilter2(c,tp)
	return c:IsCode(62340868) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter3(c)
	return c:IsCode(98434877) and c:IsFaceup()
end
function s.spfilter(c,e,tp)
	return c:IsCode(25833572) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetLP(tp)<=1000 and Duel.GetFlagEffect(tp,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|1<<32)
	Duel.Hint(HINT_CARD,tp,id)
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Check field for "Suijin", "Kazejin" and "Sanga of the Thunder"
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local b1=Duel.GetLP(tp)<=1000
	local b2=Duel.GetLP(tp)<=1000 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	--Normal Summon "Suijin", "Kazejin" and "Sanga of the Thunder" without Tributing
	if b1 and not b2 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCondition(s.ntcon)
		e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	--Normal Summmon Kazejin/Suijin/Sanga w/o Tributing or Special Summon "Gate Guardian"
	elseif b1 and b2 then
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		if op==1 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SUMMON_PROC)
			e1:SetTargetRange(LOCATION_HAND,0)
			e1:SetCondition(s.ntcon)
			e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif op==2 then
			local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
			if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
function s.ntcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsCode(25955164) or c:IsCode(62340868) or c:IsCode(98434877)
end