--Speed Duel
--Scripted by Edo9300
--fixed by MLD

getseq=Card.GetSequence
function Card.GetSequence(c)
	local seq=getseq(c)
	if c:IsLocation(LOCATION_SZONE) then
		if seq==0 then seq=1 end
		if seq==4 then seq=3 end
	end
	return seq
end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetRange(0xff)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==1
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local sdg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
		Duel.SendtoDeck(sdg,nil,-2,REASON_RULE)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.ConfirmCards(1-tp,c)
		Duel.Hint(HINT_CARD,0,id)
		--todeck
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local hct=#g-math.ceil(#g/5)
		g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
		Duel.SendtoDeck(g,nil,2,REASON_RULE)
		Duel.ShuffleDeck(tp)
		Duel.ShuffleDeck(1-tp)
		--halve LP
		local lp1=Duel.GetLP(tp)
		Duel.SetLP(tp,math.ceil(lp1/2))
		local lp2=Duel.GetLP(1-tp)
		Duel.SetLP(1-tp,math.ceil(lp2/2))
		--half deck
		local dg1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
		if #dg1>30 then
			local rg1=dg1:Select(tp,#dg1-30,#dg1-20,nil)
			Duel.SendtoDeck(rg1,nil,-2,REASON_RULE)
		end
		local dg2=Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_DECK,0,nil)
		if #dg2>30 then
			local rg2=dg2:Select(1-tp,#dg2-30,#dg2-20,nil)
			Duel.SendtoDeck(rg2,nil,-2,REASON_RULE)
		end
		--reduce extra
		local eg1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_EXTRA,0,nil)
		if #eg1>5 and #eg1<=15 then
			rg1=eg1:Select(tp,#eg1-5,#eg1,nil)
			Duel.SendtoDeck(rg1,nil,-2,REASON_RULE)
		elseif #eg1>15 then
			rg1=eg1:Select(tp,10,15,nil)
			Duel.SendtoDeck(rg1,nil,-2,REASON_RULE)
		end
		local eg2=Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_EXTRA,0,nil)
		if #eg2>5 and #eg2<=15 then
			rg2=eg2:Select(1-tp,#eg2-5,#eg2,nil)
			Duel.SendtoDeck(rg2,nil,-2,REASON_RULE)
		elseif #eg2>15 then
			rg2=eg2:Select(1-tp,10,15,nil)
			Duel.SendtoDeck(rg2,nil,-2,REASON_RULE)
		end
		--draw
		Duel.Draw(tp,hct,REASON_EFFECT)
		Duel.Draw(1-tp,hct,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(s.disop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetCode(EFFECT_SKIP_M2)
		Duel.RegisterEffect(e2,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetDescription(1135)
		Duel.RegisterEffect(e2,tp)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp,1,REASON_RULE)
	end
end
function s.disop(e,tp)
	if Duel.IsDuelType(DUEL_SEPARATE_PZONE) then
		return 0x11111111
	else
		return 0xA110A11
	end
end
