--白き龍の威光
--Majesty of the White Dragons
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Show up to 3 "Blue-Eyes White Dragon(s)" from your hand, face-up Monster Zone, and/or GY, then destroy that many cards your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Ritual Summon 1 Ritual Monster from your hand, by Tributing "Blue-Eyes White Dragon(s)" from your hand or field
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,matfilter=function(c) return c:IsCode(CARD_BLUEEYES_W_DRAGON) end,desc=aux.Stringid(id,1)})
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(Cost.SelfBanish)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON}
function s.showfilter(c)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=#sg
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then return end
	local showg=Duel.GetMatchingGroup(s.showfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if #showg==0 then return end
	local g=aux.SelectUnselectGroup(showg,e,tp,1,3,s.rescon,1,tp,HINTMSG_CONFIRM)
	local ct=#g
	if ct==0 then return end
	local confirmg,hintg=g:Split(Card.IsLocation,nil,LOCATION_HAND)
	if #confirmg>0 then Duel.ConfirmCards(1-tp,confirmg) Duel.ShuffleHand(tp) end
	if #hintg>0 then Duel.HintSelection(hintg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local desg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if #desg>0 then
		Duel.HintSelection(desg)
		Duel.BreakEffect()
		Duel.Destroy(desg,REASON_EFFECT)
	end
end