--ＶＳ ロックス
--Vanquish Soul Rocks
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 4 "Vanquish Soul" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_VANQUISH_SOUL),4,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	--All monsters your opponent controls lose 800 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.attrcon(ATTRIBUTE_DARK))
	e1:SetValue(-800)
	c:RegisterEffect(e1)
	--"Vanquish Soul" monsters you control gain 1000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.attrcon(ATTRIBUTE_FIRE))
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_VANQUISH_SOUL))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Destroy 1 card your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.attrcon(ATTRIBUTE_EARTH))
	e3:SetCost(Cost.Detach(1))
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Track battles involving "Vanquish Soul" monsters
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={28168628} -- "Rock of the Vanquisher"
s.listed_series={SET_VANQUISH_SOUL}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(0)
	if (a and a:IsSetCard(SET_VANQUISH_SOUL)) or (b and b:IsSetCard(SET_VANQUISH_SOUL)) then
		Duel.RegisterFlagEffect(0,id+100,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.ovfilter(c,tp,lc)
	return (c:IsSetCard(SET_VANQUISH_SOUL,lc,SUMMON_TYPE_XYZ,tp) or c:IsCode(28168628)) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and Duel.HasFlagEffect(0,id+100) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.attrcon(attr)
	return function(e)
		return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,attr)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end