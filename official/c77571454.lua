--Ｎｏ．６９ 紋章神コート・オブ・アームズ－ゴッド・レイジ
--Number 69: Heraldry Crest - Dark Matter Demolition
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 5 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,5)
	--Cannot be destroyed by battle or card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--Change opponent's monster's name to "Unknown"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCost(Cost.Detach(1,1,nil))
	e3:SetTarget(s.namechangetg)
	e3:SetOperation(s.namechangeop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	--Negate the activated effects of "Unknown" your opponent controls
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.xyz_number=69
s.listed_names={CARD_UNKNOWN}
function s.namechangefilter(c)
	return c:IsFaceup() and not c:IsCode(CARD_UNKNOWN)
end
function s.namechangetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.namechangefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.namechangefilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.namechangefilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.namechangeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsCode(CARD_UNKNOWN) then
		--Its name becomes "Unknown"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(CARD_UNKNOWN)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsMonsterEffect() then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) and rc:IsCode(CARD_UNKNOWN) then
			Duel.NegateEffect(ev)
		end
	end
end