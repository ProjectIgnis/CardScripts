--Deja vu
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:SetCountLimit(1)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetOperation(function(e,tp)
			Duel.GetMatchingGroup(nil,tp,0xff,0xff,nil):ForEach(s.SetInfos)
		end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_PHASE+PHASE_DRAW)
		ge2:SetOperation(function(e,tp)
			Duel.GetMatchingGroup(nil,tp,0xff,0xff,nil):ForEach(s.SetInfos)
			e:Reset()
		end)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.infos={}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.fil2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 or Duel.IsExistingMatchingCard(s.fil,tp,0xff,0xff,1,g) end
end
function s.GetInfos(c)
	if s.infos[c] then
		return table.unpack(s.infos[c])
	else
		return c:GetLocation(),c:GetPosition(),c:GetControler(),c:GetSequence(),c:IsLocation(LOCATION_PZONE)
	end
end
function s.SetInfos(c)
	s.infos[c]={c:GetLocation(),c:GetPosition(),c:GetControler(),c:GetSequence(),c:IsLocation(LOCATION_PZONE)}
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.fil2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g1=Duel.GetMatchingGroup(s.fil,tp,0xff,0xff,g)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
	e1:SetValue(0xffffff)
	Duel.RegisterEffect(e1,tp)
	for tc in aux.Next(g) do
		loc,pos,p,seq,pzone=s.GetInfos(tc)
		if (loc&LOCATION_DECK)~=0 or ((loc&LOCATION_EXTRA)~=0 and (pos&POS_FACEDOWN)~=0) then
			Duel.SendtoDeck(tc,p,2,REASON_EFFECT)
		elseif (loc&LOCATION_HAND)~=0 then
			Duel.SendtoHand(tc,p,REASON_EFFECT)
		elseif (loc&LOCATION_MZONE+LOCATION_SZONE)~=0 then
			local seq2=0
			if pzone then
				loc=LOCATION_PZONE
				if seq==4 or seq==7 then
					seq2=1
				end
			else
				seq2=seq
			end
			if Duel.MoveToField(tc,tp,p,loc,pos,true,(1<<seq2))==0 then
				Duel.ChangePosition(tc,pos)
				Duel.MoveSequence(tc,seq2)
			end
		elseif (loc&LOCATION_GRAVE)~=0 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif (loc&LOCATION_REMOVED)~=0 then
			Duel.Remove(tc,p,REASON_EFFECT)
		elseif (loc&LOCATION_EXTRA)~=0 then
			Duel.SendtoExtraP(tc,p,REASON_EFFECT)
		end
	end
	for tc in aux.Next(g1) do
		local loc,pos,p,seq=s.GetInfos(tc)
		if not Duel.GetFieldCard(p,loc,seq) then
			Duel.SpecialSummonStep(tc,0,tp,p,true,true,pos,(1<<seq))
		end
		tc=g1:GetNext()
	end
	Duel.SpecialSummonComplete()
	e1:Reset()
end
function s.fil(c)
	loc,pos,p,seq=s.GetInfos(c)
	return loc==LOCATION_MZONE and not Duel.GetFieldCard(p,LOCATION_MZONE,seq)
end
function s.fil2(c)
	loc,pos,p=s.GetInfos(c)
	return loc~=c:GetLocation() or pos~=c:GetPosition() or p~=c:GetControler()
end
