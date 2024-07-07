--エクシーズ・ポセイドン・スプラッシュ
--Xyz Poseidon Splash
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy monsters of the declared attribute that are not equipped with an Equip Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Special Summon 1 Fish, Sea Serpent, or Aqua monster from your GY to either field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.desconfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.desconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):Filter(aux.NOT(Card.HasEquipCard),nil)
	if chk==0 then return #g>0 end
	local attributes=g:GetBitwiseOr(Card.GetAttribute)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local decl_attr=Duel.AnnounceAttribute(tp,1,attributes)
	e:SetLabel(decl_attr)
	local sg=g:Filter(Card.IsAttribute,nil,decl_attr)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,tp,0)
end
function s.desfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr) and not c:HasEquipCard()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.spfilter(c,e,tp,ftpl,ftopp)
	return c:IsRace(RACE_FISH|RACE_SEASERPENT|RACE_AQUA) and
		((ftpl>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (ftopp>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ftpl=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ftopp=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ftpl,ftopp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ftpl=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ftopp=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ftpl,ftopp):GetFirst()
	if not sc then return end
	local b1=ftpl>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=ftopp>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local target_player=op==1 and tp or 1-tp
	Duel.SpecialSummon(sc,0,tp,target_player,false,false,POS_FACEUP)
end