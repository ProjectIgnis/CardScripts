--魔救の輝跡
--Adamancipator Luminous
--scripted by Naim
local s,id=GetID()
local TOKEN_GLIMMER=id+100
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Effect Monsters, including a Synchro Monster
	Link.AddProcedure(c,nil,2,2,s.linkmatcheck)
	--If this card is Link Summoned, or a monster(s) is Special Summoned to a zone(s) this card points to: You can target 1 monster in your field or GY that has a Level; Special Summon 1 "Glimmer Token" (Rock/LIGHT/ATK 0/DEF 0) with the same Level
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCondition(function(e)
		return e:GetHandler():IsLinkSummoned()
	end)
	e1a:SetTarget(s.tkntg)
	e1a:SetOperation(s.tknop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(aux.zptcon(nil))
	c:RegisterEffect(e1b)
	--When another monster on the field activates its effect (Quick Effect): You can place it on top of the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ADAMANCIPATOR}
function s.linkmatcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO,lc,sumtype,tp)
end
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:HasLevel()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GLIMMER,0,TYPES_TOKEN,0,0,c:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT)
end
function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tknop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GLIMMER,0,TYPES_TOKEN,0,0,tc:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,TOKEN_GLIMMER)
		token:Level(tc:GetLevel())
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsRelateToEffect(re) and rc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rc,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SendtoDeck(rc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end