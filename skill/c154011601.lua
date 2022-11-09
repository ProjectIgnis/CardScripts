--Monstermorph: Evolution
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop()
	for tp=0,1 do
		if not s[tp] then s[tp]=Duel.GetLP(tp) end
		if s[tp]>Duel.GetLP(tp) then
			s[2+tp]=s[2+tp]+(s[tp]-Duel.GetLP(tp))
			s[tp]=Duel.GetLP(tp)
		end
	end
end
function s.cfilter(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	local rc=c:GetOriginalRace()
	local att=c:GetOriginalAttribute()
	local eff4064256={Duel.GetPlayerEffect(tp,4064256)}
	for _,te in ipairs(eff4064256) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then rc=val(te,c,e,1) end
	end
	local eff12644061={Duel.GetPlayerEffect(tp,12644061)}
	for _,te in ipairs(eff12644061) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then att=val(te,c,e,1) end
	end
	return c:GetOriginalType()&TYPE_MONSTER~=0 and not c:IsType(TYPE_TOKEN) and lv>0 and c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,lv+1,rc,att,e,tp)
end
function s.spfilter(c,lv,rc,att,e,tp)
	return c:IsLevel(lv) and c:IsRace(rc) and c:IsAttribute(att) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return Duel.GetCurrentChain()==0 and tp==Duel.GetTurnPlayer() and s[2+tp]>=1500 and aux.CanActivateSkill(tp) and ft>-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opt register
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	--Send monster to GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	Duel.SetTargetCard(tc)
	--Evolve monster
	local tc=Duel.GetFirstTarget()
	if not (tc or tc:IsLocation(LOCATION_GRAVE)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,tc:GetLevel()+1,tc:GetRace(),tc:GetAttribute(),e,tp)
	local sc=sg:RandomSelect(tp,1)
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	s[2+tp]=0
end
   