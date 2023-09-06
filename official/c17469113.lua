--双星神 ａ－ｖｉｄａ
--Avida, Rebuilder of Worlds
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Cannot negate its Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e2)
	--Check/apply Special Summon restriction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetCost(function(_,_,tp) return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end)
	e3:SetOperation(s.spcostop)
	c:RegisterEffect(e3)
	--Shuffle all other monsters that are banished, on the field, and in the GYs into the Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
function s.spcon(e,c)
	if c==nil then return true end
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLinkMonster),0,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)
	return g:GetClassCount(Card.GetCode)>=8
end
function s.spcostop(e,tp,eg,ep,ev,re,r,rp)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.tdfilter(c)
	return c:IsMonster() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local LOCATION_MZONE_GRAVE_REMOVED=LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE_GRAVE_REMOVED,LOCATION_MZONE_GRAVE_REMOVED,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp,chk)
	local LOCATION_MZONE_GRAVE_REMOVED=LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE_GRAVE_REMOVED,LOCATION_MZONE_GRAVE_REMOVED,e:GetHandler())
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end