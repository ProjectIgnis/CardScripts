--ダーク・マター (Anime)
--Dark Matter (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x601}
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0x601) and c:IsMonster() 
		and c:IsControler(tp) and c:IsType(TYPE_SYNCHRO)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,2)
	Duel.Draw(tp,2,REASON_EFFECT)
	if g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==2 then
		for tc in aux.Next(g) do
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_DEFENSE,true)
			tc:SetStatus(STATUS_SUMMON_TURN,true)
		end
		Duel.RaiseEvent(g,EVENT_MSET,e,REASON_EFFECT,tp,tp,0)
	end
end