--御前試合
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
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
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(s.sumlimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.sumlimit)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(s.sumlimit)
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
	if sumpos and (sumpos&POS_FACEDOWN)>0 then return false end
	local at=s.getattribute(Duel.GetMatchingGroup(Card.IsFaceup,targetp or sump,LOCATION_MZONE,0,nil))
	if at==0 then return false end
	return c:GetAttribute()~=at
end
function s.getattribute(g)
	local aat=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		aat=(aat|tc:GetAttribute())
	end
	return aat
end
function s.rmfilter(c,at)
	return c:GetAttribute()==at
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if #g1==0 then s[tp]=0
	else
		local att=s.getattribute(g1)
		if (att&att-1)~=0 then
			if s[tp]==0 or (s[tp]&att)==0 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
				att=Duel.AnnounceAttribute(tp,1,att)
			else att=s[tp] end
		end
		g1:Remove(s.rmfilter,nil,att)
		s[tp]=att
	end
	if #g2==0 then s[1-tp]=0
	else
		local att=s.getattribute(g2)
		if (att&att-1)~=0 then
			if s[1-tp]==0 or (s[1-tp]&att)==0 then
				Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
				att=Duel.AnnounceAttribute(1-tp,1,att)
			else att=s[1-tp] end
		end
		g2:Remove(s.rmfilter,nil,att)
		s[1-tp]=att
	end
	g1:Merge(g2)
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE)
		Duel.Readjust()
	end
end