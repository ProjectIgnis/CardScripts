--機械龍－リボルバー・ドラゴン
--Relinquished the Wicked Eye of Illusion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Your opponent takes any battle damage you would have taken from battles involving this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If this card is in your hand: You can Tribute 2 monsters; Special Summon this card (this is treated as a Ritual Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--During the Main Phase (Quick Effect): You can target 1 Effect Monster your opponent controls; negate its effects, and if you do, equip it to this card as an Equip Spell that gives it 2000 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e3)
end
s.listed_names={id}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
function s.eqfilter(c)
	return c:IsEffectMonster() and c:IsNegatableMonster() and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsCanBeDisabledByEffect(e) then
		--Negate its effects
		tc:NegateEffects(c)
		s.equipop(c,e,tp,tc)
	end
end
function s.eqval(ec,c,tp)
	return s.eqfilter(ec) and ec:IsControler(1-tp)
end
function s.equipop(c,e,tp,tc)
	if c:EquipByEffectAndLimitRegister(e,tp,tc,id) then
		--Equip it to this card as an Equip Spell that gives it 2000 ATK
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end