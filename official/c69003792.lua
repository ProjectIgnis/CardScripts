--メガリス・アンフォームド
--Megalith Unformed
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local ritparams={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_MEGALITH),lv=s.ritlevel,location=LOCATION_DECK,sumpos=POS_FACEUP_DEFENSE}
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_END_PHASE)
	e1:SetTarget(s.target(Ritual.Target(ritparams),Ritual.Operation(ritparams)))
	c:RegisterEffect(e1)
end
s.listed_series={SET_MEGALITH}
function s.ritlevel(c)
	return c:GetLevel()*2
end
function s.target(rtg,rtop)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local b1=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0
			and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)>0
		local b2=rtg(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then return b1 or b2 end
		local stable={}
		local dtable={}
		if b1 then
			table.insert(stable,1)
			table.insert(dtable,aux.Stringid(id,0))
		end
		if b2 then
			table.insert(stable,2)
			table.insert(dtable,aux.Stringid(id,1))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=stable[Duel.SelectOption(tp,table.unpack(dtable))+1]
		e:SetLabel(op)
		if op==1 then
			e:SetCategory(CATEGORY_ATKCHANGE)
			e:SetOperation(s.atkop)
		elseif op==2 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetOperation(rtop)
			rtg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local atk=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)*(-500)
	if #g==0 or atk==0 then return end
	g:ForEach(s.op,e:GetHandler(),atk)
end
function s.op(tc,c,atk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end