--大精霊機巧軍－ペンデュラム・ルーラー
--Master Spirit Tech Force - Pendulum Ruler
--Fixed by Larry126
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--Fusion Material
	Fusion.AddProcMix(c,true,true,511009366,aux.FilterBoolFunctionEx2(Card.IsSpirit))
	--Return this card to the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.tetg)
	e1:SetOperation(s.teop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Opponent's monsters cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(function(e,c) return not c:IsType(TYPE_PENDULUM) or c:IsLevelBelow(e:GetHandler():GetLevel()) end)
	c:RegisterEffect(e3)
	--Opponent's monsters' effects are negated
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e4)
	--Gain the effect of 1 "Spirit Gem" monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.eftg)
	e5:SetOperation(s.efop)
	c:RegisterEffect(e5)
	--Place this card in your Pendulum Zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.pztg)
	e6:SetOperation(s.pzop)
	c:RegisterEffect(e6)
	aux.GlobalCheck(s,function()
		--Keep track of "Spirit Gem" monsters that used their effect
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_CHAINING)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_names={511009366}
s.listed_series={0x154e}
s.material_setcode={0x54e}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(0x154e) and re:IsMonsterEffect() then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.effilter(c)
	return c:IsFaceup() and c:IsPendulumSummoned() and c:IsSummonLocation(LOCATION_HAND)
		and c:IsSetCard(0x154e) and c:GetFlagEffect(id)==0 and c:IsReleasableByEffect()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.effilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.effilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.effilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		Duel.MajesticCopy(c,tc,RESET_EVENT+RESETS_STANDARD)
		Duel.MajesticCopy(c,tc,RESET_EVENT+RESETS_STANDARD)
		c:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,0,1) --Treated as Pendulum Summoned from hand for Spirit Gem effects
		--Double any effect damage
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,1)
		e1:SetLabel(fid)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.damval(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r&REASON_EFFECT==0 then return val end
	if re:GetHandler():GetFieldID()==e:GetLabel() then return val*2 else return val end
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_PENDULUM) and Duel.CheckPendulumZones(tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end