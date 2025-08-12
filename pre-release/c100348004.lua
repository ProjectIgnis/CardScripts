--スクラップ・シンクロン
--Scrap Synchron
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--For a Synchro Summon, you can substitute this card for any 1 "Synchron" Tuner ("Quickdraw Synchron")
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(20932152)
	c:RegisterEffect(e0)
	--If you Synchro Summon a monster that mentions a "Synchron" Tuner as material, this card in your hand can also be used as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(function(e,mc,sc) return sc:ListsArchetypeAsMaterial(SET_SYNCHRON) end)
	c:RegisterEffect(e1)
	--If a monster(s) that mentions "Junk Warrior", and/or a Synchro Monster(s) with "Warrior" in its original name, that you control would be destroyed by battle or card effect, you can banish this card from your field or GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e2:SetOperation(function(e) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SYNCHRON,SET_WARRIOR}
s.listed_names={CARD_JUNK_WARRIOR}
function s.repfilter(c,tp)
	return (c:ListsCode(CARD_JUNK_WARRIOR) or (c:IsSynchroMonster() and c:IsOriginalSetCard(SET_WARRIOR))) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end