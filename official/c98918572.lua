--十二獣の相剋
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--remove overlay replace
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rcon)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
s.listed_series={0xf1}
function s.rfilter(c,oc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,oc,REASON_COST)
end
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return (r&REASON_COST)~=0 and re:IsHasType(0x7e0)
		and re:IsActiveType(TYPE_XYZ) and ep==e:GetOwnerPlayer() and rc:IsSetCard(0xf1)
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,0,1,rc,ev)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local ct=(ev&0xffff)
	local rc=re:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE,0,1,1,rc,ct)
	tg:GetFirst():RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xf1)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g1=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g2=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local tc=g:GetFirst()
	local xc=g:GetNext()
	if xc==e:GetLabelObject() then tc,xc=xc,tc end
	if not tc:IsImmuneToEffect(e) then
		local og=xc:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(tc,Group.FromCards(xc))
	end
end
