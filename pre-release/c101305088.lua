--JP name
--Imposter Shift
--scripted by pyrQ
local s,id=GetID()
local TOKEN_IMPOSTER=id+100
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--When a monster effect that was activated on your opponent's field by targeting a card(s) on the field resolves, if any of those targets are in a different column than that opponent's monster, they can banish 1 card from their GY. If they did not, negate the activated effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--You can banish 1 monster from your GY; Special Summon 1 "Imposter Token" (Psychic/EARTH/ATK 800/DEF 800) with the same Level as that monster. You can only use this effect of "Imposter Shift" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tokencost)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_IMPOSTER}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local rc=re:GetHandler()
	if re:IsMonsterEffect() and rc:IsRelateToEffect(re) and rc:IsControler(opp) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and Chain.IsTriggeringLocation(ev,LOCATION_MZONE) and Chain.IsTriggeringControler(ev,opp) and Chain.IsDisablable(ev) then
		local tg=Chain.GetTargetCards(ev)
		return tg and tg:IsExists(aux.AND(Card.IsRelateToEffect,Card.IsOnField),1,nil,re)
	end
	return false
end
function s.disconfilter(c,seq,ctrl)
	return not c:IsColumn(seq,ctrl,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local tg=Chain.GetTargetCards(ev):Filter(aux.AND(Card.IsRelateToEffect,Card.IsOnField),nil,re)
	if tg:IsExists(s.disconfilter,1,nil,re:GetHandler():GetSequence(),opp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,opp,LOCATION_GRAVE,0,1,nil,opp)
		and Duel.SelectYesNo(opp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(opp,Card.IsAbleToRemove,opp,LOCATION_GRAVE,0,1,1,nil,opp)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT,nil,opp)
		end
	else
		Duel.NegateEffect(ev)
	end
end
function s.tokencostfilter(c,tp)
	return c:HasLevel() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0 and aux.SpElimFilter(c,true)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_IMPOSTER,0,TYPES_TOKEN,800,800,c:GetLevel(),RACE_PSYCHIC,ATTRIBUTE_EARTH)
end
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tokencostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.tokencostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	e:GetChainData().token_level=sc:GetLevel()
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local token_level=e:GetChainData().token_level
	if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_IMPOSTER,0,TYPES_TOKEN,800,800,token_level,RACE_PSYCHIC,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,TOKEN_IMPOSTER)
		token:Level(token_level)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end