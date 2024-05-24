--童妖 茶壺
--Procession of the Tea Jar
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Face-down Defense Position monsters in this card's column cannot change battle positions
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.coltg)
	c:RegisterEffect(e1)
	--Cannot activate Set cards in this card's column's Spell & Trap Zones
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(function(e,re) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and s.coltg(e,re:GetHandler()) end)
	c:RegisterEffect(e2)
	--Move this card to an unused adjacent Main Monster Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(aux.seqmovcon)
	e3:SetOperation(aux.seqmovop)
	c:RegisterEffect(e3)
	--Change all other monsters in this card's column to face-down Defense Position
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_MOVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
end
function s.coltg(e,c)
	return c:IsFacedown() and e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.posfilter(c)
	return c:IsCanTurnSet() and c:IsLocation(LOCATION_MZONE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetColumnGroup():Filter(s.posfilter,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetColumnGroup():Filter(s.posfilter,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
