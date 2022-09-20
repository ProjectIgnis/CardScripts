--ＥＭマンモスプラッシュ (Anime)
--Performapal Splashmammoth (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Allow use of 1 monster from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Fusion Summon
	local params = {nil,nil,nil,s.extraop,Fusion.ForcedHandler}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasCategory(CATEGORY_FUSION_SUMMON) or re:GetHandler():IsSetCard(0x46)) and rp==tp
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Extra Fusion Material
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCanBeFusionMaterial() end)
	e1:SetValue(1)
	e1:SetLabelObject({s.extrafil_replacement})
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),0,tp,1,0,aux.Stringid(id,1))
end
function s.extrafil_repl_filter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsCanBeFusionMaterial()
end
function s.extrafil_replacement(e,tp,mg)
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_EXTRA,0,nil)
	return g,s.fcheck_replacement
end
function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end 
function s.extraop(e,tc,tp,sg,chk)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(LOCATION_REMOVED)
	e:GetHandler():RegisterEffect(e3)
end
