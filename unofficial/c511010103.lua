--Ｎｏ．１０３ 神葬零嬢ラグナ・ゼロ (Anime)
--Number 103: Ragnazero (Anime)
Duel.EnableUnofficialProc(PROC_STATS_CHANGED)
Duel.LoadCardScript("c94380860.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(id)
	e1:SetCountLimit(1)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--battle indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e2)
end
s.xyz_number=103
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,e,tp) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.desfilter(c,e,tp)
	return c:IsControler(1-tp) and (not e or c:IsRelateToEffect(e))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=eg:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
