--Ｓ－Ｆｏｒｃｅ ミスティファイ
--S-Force Mystify
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including an "S-Force" monster
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	--While an opponent's monster is in this card's column, your opponent cannot target this card with card effects, also they cannot Special Summon with activated monster effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.columncon)
	e1a:SetValue(aux.tgoval)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetTargetRange(0,1)
	e1b:SetCondition(s.columncon)
	e1b:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se) return se and se:IsActivated() and se:IsMonsterEffect() end)
	c:RegisterEffect(e1b)
	--(Quick Effect): You can target 1 monster on the field; move it to another of its controller's Main Monster Zones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_S_FORCE}
s.material_setcode={SET_S_FORCE}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_S_FORCE,lc,sumtype,tp)
end
function s.columnfilter(c,opp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(opp)
end
function s.columncon(e)
	return e:GetHandler():GetColumnGroup():IsExists(s.columnfilter,1,nil,1-e:GetHandlerPlayer())
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local own_loc=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and LOCATION_MZONE or 0
	local opp_loc=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and LOCATION_MZONE or 0
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and (chkc:IsControler(tp) and (own_loc>0) or (opp_loc>0)) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,own_loc,opp_loc,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,nil,tp,own_loc,opp_loc,1,1,nil)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local player=tc:GetControler()
	if Duel.GetLocationCount(player,LOCATION_MZONE)>0 then
		local is_own=player==tp
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local zone=Duel.SelectDisableField(tp,1,is_own and LOCATION_MZONE or 0,is_own and 0 or LOCATION_MZONE,0)
		if not is_own then zone=zone>>16 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		Duel.MoveSequence(tc,math.log(zone,2))
	end
end