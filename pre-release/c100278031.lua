--ステルス・クラーゲン・エフィラ
--Kragen Spawn
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
s.listed_series={0x48,0x267}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if rc and re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x48) and rc:IsType(TYPE_XYZ) then
		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE-RESET_REMOVE)
		e3:SetCondition(s.spcon)
		e3:SetTarget(s.sptg)
		e3:SetOperation(s.spop)
		c:RegisterEffect(e3)
		--Record of each materials before this card leaves the field
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_LEAVE_FIELD_P)
		e4:SetOperation(s.recordop)
		e4:SetLabelObject(e3)
		c:RegisterEffect(e4)
	end
end
function s.recordop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x267) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),#e:GetLabelObject())
	if ct<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ct,e:GetHandler(),e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local og=Duel.GetOperatedGroup()
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAttribute),tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_WATER)
		if #og>0 and #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local xg=mg:Select(tp,1,#og,nil)
			for xc in aux.Next(xg) do
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local tc=og:Select(tp,1,1,nil):GetFirst()
				Duel.Overlay(tc,xc)
			end
		end
	end
end