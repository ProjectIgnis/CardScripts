--四獣層ウォンキー
--Wonky Quartet
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,4,2,nil,nil,Xyz.InfiniteMats)
	--Unaffected by other cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1)
	--Attach the top 3 cards of your Deck to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	c:RegisterEffect(e3)
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,c,1,1-tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,tp,400)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,3)
	if not (c:IsRelateToEffect(e) and #g==3) then return end
	Duel.DisableShuffleCheck()
	Duel.Overlay(c,g)
	local og=c:GetOverlayGroup()
	if og:FilterCount(Card.IsMonster,nil)<=4 then
		Duel.BreakEffect()
		Duel.GetControl(c,1-tp)
	else
		Duel.BreakEffect()
		if Duel.Damage(tp,#og*400,REASON_EFFECT)>0 then
			local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
			if #dg==0 then return end
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
