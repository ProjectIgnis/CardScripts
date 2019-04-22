--Unexpected Daian
--AlphaKretin
function c210310260.initial_effect(c)
	c:EnableReviveLimit()
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c210310260.sprcon)
	e1:SetOperation(c210310260.sprop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62624486,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c210310260.spcon)
	e2:SetTarget(c210310260.sptg)
	e2:SetOperation(c210310260.spop)
	c:RegisterEffect(e2)
end
function c210310260.sprfilter(c)
	return c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end
function c210310260.sprfilter1(c,tp,g,sc)
	return c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_SPELL) and g:IsExists(c210310260.sprfilter2,1,c,tp,c,sc)
end
function c210310260.sprfilter2(c,tp,mc,sc)
	local sg=Group.FromCards(c,mc)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
		and ((not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(4)) or c:IsSetCard(0xf36))
end
function c210310260.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c210310260.sprfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	return g:IsExists(c210310260.sprfilter1,1,nil,tp,g,c)
end
function c210310260.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(c210310260.sprfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=g:FilterSelect(tp,c210310260.sprfilter1,1,1,nil,tp,g,c)
	local mc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=g:FilterSelect(tp,c210310260.sprfilter2,1,1,mc,tp,mc,c)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end
function c210310260.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE) 
end
function c210310260.filter(c,e,tp)
	return c:IsLevelBelow(4) and (not c:IsType(TYPE_EFFECT) or c:IsSetCard(0xf36)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210310260.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210310260.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c210310260.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210310260.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end