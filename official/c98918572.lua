--十二獣の相剋
--Zoodiac Gathering
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--If a "Zoodiac" Xyz Monster you control would detach its Xyz Material(s) you can detach from another Xyz Monster(s) you control instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rcon)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)
	--Attach 1 "Zoodiac" Xyz monster to another
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZOODIAC}
function s.rfilter(c,tp,oc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,oc,REASON_COST)
end
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return (r&REASON_COST)~=0 and re:IsActivated()
		and re:IsActiveType(TYPE_XYZ) and ep==e:GetOwnerPlayer() and rc:IsSetCard(SET_ZOODIAC)
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,0,1,rc,tp,ev)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local ct=(ev&0xffff)
	local rc=re:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local tg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE,0,1,1,rc,tp,ct)
	tg:GetFirst():RemoveOverlayCard(tp,ct,ct,REASON_COST)
	return ct
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_ZOODIAC)
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
		Duel.Overlay(tc,xc,true)
	end
end