--嵐闘機旗艦バハムートボマー改
--Stormriderflagship Custom Bahamut Bomber
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ "Stormrider" Link Monsters
	Link.AddProcedure(c,s.matfilter,2)
	--Place 1 opponent's monster in their Spell & Trap Zone as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_STZONE,0,1,nil) end)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Destroy as many cards in your opponent's Spell & Trap Zone as possible
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_STZONE,0,1,nil) end)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
local SET_STORMRIDER=0x580
s.listed_series={SET_STORMRIDER}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_LINK,lc,sumtype,tp) and c:IsSetCard(SET_STORMRIDER,lc,sumtype,tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)>0
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_STZONE,0)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
	Duel.SetChainLimit(function(_e,_ep,_tp) return _tp==_ep end)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_STZONE,0)
	if #g==0 then return end
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end