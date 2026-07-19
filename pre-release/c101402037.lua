--Ｄ－ＨＥＲＯ ドレッドノートガイ
--Destiny HERO - Dreadnought
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 Level 5 or higher "Destiny HERO" monsters
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Must be either Fusion Summoned, or Special Summoned (from your Extra Deck) by Tributing 1 "Destiny HERO - Dreadmaster"
	c:AddMustBeFusionSummoned()
	local e0a=Effect.CreateEffect(c)
	e0a:SetDescription(aux.Stringid(id,0))
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_SPSUMMON_PROC)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCondition(s.selfspcon)
	e0a:SetTarget(s.selfsptg)
	e0a:SetOperation(s.selfspop)
	e0a:SetValue(1)
	c:RegisterEffect(e0a)
	--You can only Special Summon "Destiny HERO - Dreadnought" once per turn this way, no matter which method you use
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0b:SetCondition(s.regcon)
	e0b:SetOperation(s.regop)
	c:RegisterEffect(e0b)
	--If this card is Special Summoned: You can add 2 "Destiny HERO" monsters and/or cards that mention a "Destiny HERO" monster's card name from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--This card's ATK becomes the total original ATK of all other "Destiny HERO" monsters in your field and GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DESTINY_HERO),c:GetControler(),LOCATION_MZONE|LOCATION_GRAVE,0,c):GetSum(Card.GetBaseAttack) end)
	c:RegisterEffect(e2)
end
s.listed_names={40591390} --"Destiny HERO - Dreadmaster"
s.listed_series={SET_DESTINY_HERO}
s.material_setcode={SET_DESTINY_HERO,SET_HERO}
function s.matfilter(c,fc,sumtype,sump)
	return c:IsLevelAbove(5) and c:IsSetCard(SET_DESTINY_HERO,fc,sumtype,sump)
end
function s.selfspcostfilter(c,tp,fc)
	return c:IsSummonCode(fc,MATERIAL_FUSION,tp,40591390) and c:IsCanBeFusionMaterial(fc,MATERIAL_FUSION,tp) and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
function s.selfspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.selfspcostfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.selfspcostfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if g and #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g and #g>0 then
		Duel.Release(g,REASON_COST|REASON_MATERIAL)
	end
end
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You can only Special Summon "Destiny HERO - Dreadnought" once per turn this way, no matter which method you use
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCodeRule(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return ((c:IsSetCard(SET_DESTINY_HERO) and c:IsMonster()) or c:ListsCodeWithArchetype(SET_DESTINY_HERO)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end