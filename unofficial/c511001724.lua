--花札衛－牡丹に蝶－ (Anime)
--Flower Cardian Peony with Butterfly (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_CARDIAN)
	--synchro level
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_FLOWER_CARDIAN}
function s.filter(c)
    local re=c:GetReasonEffect()
    return c:IsLevel(6) and c:IsSetCard(SET_FLOWER_CARDIAN) and (not c:IsSummonType(SUMMON_TYPE_SPECIAL)
        or (not re or not re:GetHandler():IsSetCard(SET_FLOWER_CARDIAN) or not re:GetHandler():IsMonster()))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filter,1,false,aux.ReleaseCheckMMZ,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectReleaseGroupCost(tp,s.filter,1,1,false,aux.ReleaseCheckMMZ,nil)
    Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		Duel.Draw(tp,1,REASON_EFFECT)
		if tc then
			Duel.ConfirmCards(1-tp,tc)
			if Cardian.CheckSpCondition(tc) then
				Duel.ShuffleHand(tp)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc)
		or sg:CheckWithSumEqual(function() return 2 end,lv,#sg,#sg)
	return res,true
end
