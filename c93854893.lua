--宵星の機神ディンギルス
--Sheorcust Dingirsu
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--xyz summon
	Xyz.AddProcedure(c,nil,8,2,s.ovfilter,aux.Stringid(id,0),2)
	c:EnableReviveLimit()
	--on summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
end
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0x11b,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.tgtg(e,tp,eg,ep,ev,re,r,rp,0) or s.mattg(e,tp,eg,ep,ev,re,r,rp,0) end
	local sel
	if s.tgtg(e,tp,eg,ep,ev,re,r,rp,0) and s.mattg(e,tp,eg,ep,ev,re,r,rp,0) then
		sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif s.tgtg(e,tp,eg,ep,ev,re,r,rp,0) then
		sel=0
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
	else 
		sel=1
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
	end
	e:SetLabel(sel)
	if sel==0 then
		s.tgtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		s.mattg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		s.tgop(e,tp,eg,ep,ev,re,r,rp)
	else
		s.matop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	e:SetCategory(CATEGORY_TOGRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ) 
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_MACHINE),tp,LOCATION_REMOVED,0,1,nil) end
	e:SetCategory(0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_MACHINE),tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.Overlay(c,g)
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

