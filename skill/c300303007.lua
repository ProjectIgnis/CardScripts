--Union Combination
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp)
end
function s.exfilter(c)
	local se=c:GetCardEffect(EFFECT_SPSUMMON_PROC)
	if not se then return false end
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsType(TYPE_FUSION) and c:IsMonster() 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local g=Duel.GetMatchingGroup(s.exfilter,tp,0xff,0,nil)
	for tc in aux.Next(g) do
		local se=tc:GetCardEffect(EFFECT_SPSUMMON_PROC)
		if se then
			se:Reset()
			Fusion.AddContactProc(tc,s.contactfil,s.contactop,s.splimit)
		end
	end
end
function s.contactfil(tp)
	local loc=LOCATION_ONFIELD
	if Duel.GetFlagEffect(tp,id+100)==0 then
		loc=LOCATION_ONFIELD+LOCATION_GRAVE
	end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g,tp,c)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		--Can only apply this effect OPT
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
		--Opponent takes no damage this turn
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CHANGE_DAMAGE)
		ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge1:SetTargetRange(0,1)
		ge1:SetValue(0)
		ge1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		ge2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge2,tp)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end