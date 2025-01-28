--Ｅ－ＨＥＲＯ インフェルノ・ウィング－ヘルバック・ファイア
--Evil HERO Inferno Wing - Backfire
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Elemental HERO Avian" or "Elemental HERO Burstinatrix" + 1 "HERO" monster
	Fusion.AddProcMix(c,true,true,{21844576,58932615},aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HERO))
	c:AddMustBeSpecialSummonedByDarkFusion()
	--Add 1 "Dark Fusion" or 1 card that mentions it from your Deck or GY to your hand, except a Fusion Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Inflict 2100 damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
s.listed_names={21844576,58932615,CARD_DARK_FUSION} --"Elemental HERO Avian", "Elemental HERO Burstinatrix"
s.listed_series={SET_HERO}
function s.thfilter(c)
	return (c:IsCode(CARD_DARK_FUSION) or c:ListsCode(CARD_DARK_FUSION)) and not c:IsType(TYPE_FUSION) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.damconfilter(c,tp)
	if not c:IsStatus(STATUS_OPPO_BATTLE) then return false end
	if c:IsRelateToBattle() then
		return c:IsSetCard(SET_HERO) and c:IsControler(tp)
	else
		return c:IsPreviousSetCard(SET_HERO) and c:IsPreviousControler(tp)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damconfilter,1,nil,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(2100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2100)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end