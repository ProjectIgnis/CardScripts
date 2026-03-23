--スカーレッド・ノヴァ・ドラゴン－バーニング・ソウル
--Red Nova Dragon - Burning Soul
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedue: 2 Tuners + 1 non-Tuner
	Synchro.AddProcedure(c,nil,2,2,Synchro.NonTuner(nil),1,1)
	--Must be either Synchro Summoned, or Special Summoned (from your Extra Deck) by banishing 2 Tuners and 1 "Red Dragon Archfiend" from your GY
	c:AddMustBeSynchroSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--If this card is Special Summoned: You can add 1 card from your GY to your hand, and if you do, this card gains 2000 ATK. You can only use this effect of "Red Nova Dragon - Burning Soul" once per Duel, and only during a Duel you Synchro Summoned "Red Dragon Archfiend"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(function(e,tp) return Duel.HasFlagEffect(tp,id) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Track Synchro Summons of "Red Dragon Archfiend"
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Multiple Tuners
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_MULTIPLE_TUNERS)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.spcostfilter(c)
	return (c:IsType(TYPE_TUNER) or c:IsCode(CARD_RED_DRAGON_ARCHFIEND)) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:IsExists(Card.IsType,2,nil,TYPE_TUNER) and sg:IsExists(Card.IsCode,1,nil,CARD_RED_DRAGON_ARCHFIEND)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	return #g>=2 and Duel.GetMZoneCount(tp,g)>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if sg then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,2000)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local c=e:GetHandler()
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card gains 2000 ATK
		c:UpdateAttack(2000)
	end
end
function s.regopfilter(c,sp)
	return c:IsCode(CARD_RED_DRAGON_ARCHFIEND) and c:IsSummonPlayer(sp) and c:IsSynchroSummoned() and c:IsFaceup()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(0,id) and Duel.HasFlagEffect(1,id) then return end
	for sp=0,1 do
		if eg:IsExists(s.regopfilter,1,nil,sp) then
			Duel.RegisterFlagEffect(sp,id,0,0,1)
		end
	end
end