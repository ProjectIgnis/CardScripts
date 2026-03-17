--ヴァレルエンド・ドラゴン
--Borrelend Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 3+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--Cannot be destroyed by battle or card effects, also neither player can target this card with monster effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1c:SetValue(function(e,re,rp) return re:IsMonsterEffect() end)
	c:RegisterEffect(e1c)
	--Can attack all monsters your opponent controls, once each
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--(Quick Effect): You can target 1 Effect Monster on the field and 1 "Rokket" monster in your GY; negate the effects of that monster on the field, and if you do, Special Summon that other monster from your GY. Your opponent cannot activate cards or effects in response to this effect's activation. You can only use this effect of "Borrelend Dragon" once per turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ROKKET}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ROKKET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(aux.AND(Card.IsEffectMonster,Card.IsNegatableMonster),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g1=Duel.SelectTarget(tp,aux.AND(Card.IsEffectMonster,Card.IsNegatableMonster),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetChainLimit(function(e,ep,tp) return tp==ep end)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local field_tc=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	if field_tc and field_tc:IsMonster() and field_tc:IsFaceup() and field_tc:IsCanBeDisabledByEffect(e) then
		--Negate the effects of that monster on the field
		field_tc:NegateEffects(e:GetHandler())
		Duel.AdjustInstantly(field_tc)
		local gy_tc=tg-field_tc
		if field_tc:IsDisabled() and #gy_tc>0 then
			Duel.SpecialSummon(gy_tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end