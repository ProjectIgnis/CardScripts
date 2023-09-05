--群雄割拠
--Rivalry of Warlords
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.acttg)
	c:RegisterEffect(e1)
	--adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	--cannot summon,spsummon,flipsummon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(s.sumlimit)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
end
s[0]=0
s[1]=0
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s[0]=0
	s[1]=0
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local rc=s.getrace(Duel.GetMatchingGroup(Card.IsFaceup,targetp or sump,LOCATION_MZONE,0,nil))
	if rc==0 then return false end
	return c:GetRace()~=rc
end
function s.getrace(g)
	local arc=0
	for tc in g:Iter() do
		arc=(arc|tc:GetRace())
	end
	return arc
end
function s.rmfilter(c,rc)
	return c:GetRace()==rc
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if #g1==0 then
		s[tp]=0
	else
		local rac=s.getrace(g1)
		if (rac&rac-1)~=0 then
			if s[tp]==0 or (s[tp]&rac)==0 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
				rac=Duel.AnnounceRace(tp,1,rac)
			else rac=s[tp] end
		end
		g1:Remove(s.rmfilter,nil,rac)
		s[tp]=rac
	end
	if #g2==0 then
		s[1-tp]=0
	else
		local rac=s.getrace(g2)
		if (rac&rac-1)~=0 then
			if s[1-tp]==0 or (s[1-tp]&rac)==0 then
				Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
				rac=Duel.AnnounceRace(1-tp,1,rac)
			else rac=s[1-tp] end
		end
		g2:Remove(s.rmfilter,nil,rac)
		s[1-tp]=rac
	end
	local readjust=false
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,tp)
		readjust=true
	end
	if #g2>0 then
		Duel.SendtoGrave(g2,REASON_RULE,PLAYER_NONE,1-tp)
		readjust=true
	end
	if readjust then Duel.Readjust() end
end