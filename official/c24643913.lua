--叛逆者エト
--Liberator Eto
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your hand or GY) by paying half your LP while your opponent has a Monster Card on their field or GY with an effect that activates in the hand or Monster Zone in response to a card or effect activation
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon)
	e0:SetOperation(function(e,tp) Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end)
	c:RegisterEffect(e0)
	--This card's Special Summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e1)
	--While this card is in the Monster Zone, it cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e2)
	--Unaffected by monster effects activated on your opponent's field during your turn only
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.spconfilter(c)
	if not (c:IsMonsterCard() and c:IsFaceup()) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasType(EFFECT_TYPE_QUICK_O|EFFECT_TYPE_QUICK_F) and eff:GetCode()==EVENT_CHAINING
			and (eff:GetRange()&(LOCATION_HAND|LOCATION_MZONE))>0 then
			return true
		end
	end
	return false
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
end
function s.immval(e,te)
	if not (te:IsMonsterEffect() and te:IsActivated()) then return false end
	local trig_loc,trig_ctrl=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	local tp=e:GetHandlerPlayer()
	if not Duel.IsChainSolving() then
		local tc=te:GetHandler()
		return tc:IsLocation(LOCATION_MZONE) and tc:IsControler(1-tp)
	else
		return trig_loc==LOCATION_MZONE and trig_ctrl==1-tp
	end
end