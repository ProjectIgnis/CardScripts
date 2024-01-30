--フュージョンキャンセル
--Fusion Cancel
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 face-up Fusion Monster on the field to the owner's Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_FUSION) and c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.sumfilter(c,e,tp,fc)
	return c:IsCode(table.unpack(fc.material)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #dg==0 then return end
	dg=dg:AddMaximumCheck()
	Duel.HintSelection(dg,true)
	if Duel.SendtoDeck(dg,nil,0,REASON_EFFECT)==0 then return end
	local tc=dg:GetFirst()
	local sp=tc:GetOwner()
	--cannot summon anything if not all the materials are specifically named
	if tc.named_material and #tc.named_material~=tc.min_material_count then return end
	if tc.material==nil then return end
	if Duel.GetLocationCount(sp,LOCATION_MZONE)<tc.min_material_count then return end
	local sg=Duel.GetMatchingGroup(s.sumfilter,sp,LOCATION_GRAVE,0,nil,e,sp,tc)
	if aux.SelectUnselectGroup(sg,e,sp,tc.min_material_count,tc.min_material_count,s.rescon(tc),0) and Duel.SelectYesNo(sp,aux.Stringid(id,1)) then
		local spg=aux.SelectUnselectGroup(sg,e,sp,tc.min_material_count,tc.max_material_count,s.rescon(tc),1,sp,HINTMSG_SPSUMMON)
		if #spg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(spg,0,sp,sp,false,false,POS_FACEUP)
		end
	end
end
function s.rescon(tc)
	return function(sg,e,tp,mg)
		return sg:GetClassCount(Card.GetCode)==#tc.material
	end
end
