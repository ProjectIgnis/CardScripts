--超再生能力
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if s.counter==nil then
		s.counter=true
		s[0]=0
		s[1]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(s.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_RELEASE)
		e3:SetOperation(s.addcount)
		Duel.RegisterEffect(e3,0)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_DISCARD)
		e4:SetOperation(s.addcount)
		Duel.RegisterEffect(e4,0)
	end
end
function s.resetcount(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		local pl=tc:GetPreviousLocation()
		if pl==LOCATION_MZONE and tc:GetPreviousRaceOnField()==RACE_DRAGON then
			local p=tc:GetReasonPlayer()
			s[p]=s[p]+1
		elseif pl==LOCATION_HAND and tc:IsType(TYPE_MONSTER) and tc:GetOriginalRace()==RACE_DRAGON then
			local p=tc:GetPreviousControler()
			s[p]=s[p]+1
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.droperation)
	Duel.RegisterEffect(e1,tp)
end
function s.droperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,s[tp],REASON_EFFECT)
end
