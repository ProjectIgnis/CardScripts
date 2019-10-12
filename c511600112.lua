--Ｄスケイル・バトルシーラ
--D-Scale Battle Coela
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x579),2,2)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4013,12))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4013,13))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
s.listed_series={0x579}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()&0x1f
	if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL,zone)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=c:GetLinkedZone()&0x1f
	if Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL,zone)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local nseq=math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~zone),2)
		Duel.MoveSequence(c,nseq)
	end
end
function s.zonefilter(c)
	local lg=c:GetLinkedGroup()
	local zone=0
	for lc in aux.Next(lg) do
		zone=zone|lc:GetLinkedZone()&0x1f
	end
	return zone
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=s.zonefilter(e:GetHandler())
	if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL,zone)>0 end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=s.zonefilter(c)
	if Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL,zone)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local nseq=math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~zone),2)
		Duel.MoveSequence(c,nseq)
	end
end