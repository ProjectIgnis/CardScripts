--created & coded by Lyris, clip art at http://sweetclipart.com/multisite/sweetclipart/files/fleur_de_lis_black_silhouette.png
--剣主のオース
function c210410014.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,210410014+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c210410014.tg2)
	e2:SetOperation(c210410014.op2)
	c:RegisterEffect(e2)
end
function c210410014.filter(c,e,tp)
	return c:IsSetCard(0xfb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210410014.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetOverlayGroup(tp,1,0):IsExists(c210410014.filter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function c210410014.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetOverlayGroup(tp,1,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:FilterSelect(tp,c210410014.filter,1,1,nil,e,tp)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
