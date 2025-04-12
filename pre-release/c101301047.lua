--流麗の騎士ガイアストリーム
--Gaia Stream, the Graceful Force
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 6 monsters OR 1 Rank 5 or 7 Xyz Monster you control
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	--Cannot be used as material for an Xyz Summon the turn it was Xyz Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(s.matxyzcond)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Cannot attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--Gains ATK equal to the combined Levels/Ranks of its attached materials x 200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Detach 1 material from this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetOperation(s.detachop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.ovfilter(c,tp,lc)
	return c:IsRank(5,7) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
function s.matxyzcond(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsXyzSummoned()
end
function s.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(aux.OR(Card.HasLevel,Card.HasRank),nil)
	return 200*(g:GetSum(Card.GetLevel)+g:GetSum(Card.GetRank))
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end