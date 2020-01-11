--Scripted by Eerie Code
--Performage Overlay Juggler
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Xyz to material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.xmtg)
	e2:SetOperation(s.xmop)
	c:RegisterEffect(e2)
	--Attach
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end

function s.xmfil1(c,tp)
	return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.xmfil2,tp,LOCATION_MZONE,0,1,c,c)
end
function s.xmfil2(c,xyzmat)
	return c:IsType(TYPE_XYZ) and xyzmat:IsCanBeXyzMaterial(c)
end
function s.xmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xmfil1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xmfil1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xmfil1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.xmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.xmfil2,tp,LOCATION_MZONE,0,1,1,tc,tc)
		if #g>0 and not g:GetFirst():IsImmuneToEffect(e) then
			if tc:GetOverlayCount()>0 then
				Duel.SendtoGrave(tc:GetOverlayGroup(),REASON_RULE)
			end
			Duel.Overlay(g:GetFirst(),Group.FromCards(tc))
		end
	end
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xmfil2(chkc,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(s.xmfil2,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xmfil2,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
