--ナチュル・ホーストニードル
--Naturia Horneedle
local s,id=GetID()
function s.initial_effect(c)
	--Destroy Special Summoned monster(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.CostWithReplace(s.descost,CARD_NATURIA_CAMELLIA))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NATURIA}
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,aux.FaceupFilter(Card.IsSetCard,SET_NATURIA),1,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,aux.FaceupFilter(Card.IsSetCard,SET_NATURIA),1,1,false,nil,c)
	Duel.Release(g,REASON_COST)
end
function s.desfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.desfilter,nil,nil,tp)
	if chk==0 then return #g>0 and not c:IsStatus(STATUS_CHAINING) and not eg:IsContains(c) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end