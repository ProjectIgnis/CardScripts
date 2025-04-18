--混沌の夢魔鏡
--Dream Mirror of Chaos
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 "Dream Mirror" fusion monster
	--Using monsters from your field as material
	--If "Dream Mirror of Joy" is on the field, include from hand as well
	--If "Dream Mirror of Terror" is on the field, banish from GY as well
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_DREAM_MIRROR),
		matfilter=Fusion.OnFieldMat,extrafil=s.fextra,extraop=s.extraop,extratg=s.extrtarget})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DREAM_MIRROR}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}
function s.fextra(e,tp,mg)
	local joy=Duel.IsEnvironment(CARD_DREAM_MIRROR_JOY,PLAYER_ALL,LOCATION_FZONE)
	local terror=Duel.IsEnvironment(CARD_DREAM_MIRROR_TERROR,PLAYER_ALL,LOCATION_FZONE) and not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION)
	local joyg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_HAND,0,nil)
	local terrorg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	if joy and terror then
		joyg:Merge(terrorg)
		return joyg
	end
	if joy then return joyg end
	if terror then return terrorg end
end
function s.extraop(e,tc,tp,sg)
	local g1=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Sub(g1)
end
function s.extrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end